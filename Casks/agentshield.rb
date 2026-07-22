cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1712"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1712/agentshield_0.2.1712_darwin_amd64.tar.gz"
      sha256 "34ac8d46b61769f3198e259c7333eae0cbbca9bef74cc0300d3e67f83336c69f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1712/agentshield_0.2.1712_darwin_arm64.tar.gz"
      sha256 "04cd7e6c8a007f03e1fad409adedd6d9533e1033e1d67e40aede3ec8ad8c04fb"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1712/agentshield_0.2.1712_linux_amd64.tar.gz"
      sha256 "3bc24ae2311a1c259f88056871c34d859e9d5ae50adda3b89d1f565da29543ad"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1712/agentshield_0.2.1712_linux_arm64.tar.gz"
      sha256 "65b5637ffa0325c07471aee0c2bffc738e5b14ed64679254969b1f7860cc5c6a"
    end
  end

  # Stop the heartbeat daemon before upgrading so the old binary doesn't keep
  # running as a zombie after brew replaces it.
  preflight do
    if OS.mac?
      plist = File.expand_path("~/Library/LaunchAgents/com.aiagentlens.agentshield.plist")
      if File.exist?(plist)
        system_command "/bin/launchctl", args: ["bootout", "gui/#{Process.uid}/com.aiagentlens.agentshield"], print_stderr: false
        File.delete(plist) if File.exist?(plist)
      end
    end
  end

  postflight do
    if OS.mac?
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentshield"]
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentcompliance"]
    end
  end

  uninstall launchctl: "com.aiagentlens.agentshield",
            delete:    "~/Library/LaunchAgents/com.aiagentlens.agentshield.plist"

  caveats <<~EOS
    Two tools installed:
      agentshield      — Runtime security gateway for AI agents
      agentcompliance  — Local compliance scanner (semgrep-based)

    Quick start:
      agentshield setup
      agentshield login
  EOS
end

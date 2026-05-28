cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1130"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1130/agentshield_0.2.1130_darwin_amd64.tar.gz"
      sha256 "7ab4e53fc450f99753e05cea65cbd94bdabd04d3191ff309d665390993696f23"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1130/agentshield_0.2.1130_darwin_arm64.tar.gz"
      sha256 "70f79140288c5a0bfa5d9b239d46219b0e67b7fd21cea667aa8ea97bdff39685"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1130/agentshield_0.2.1130_linux_amd64.tar.gz"
      sha256 "15a66536d7042366fd5299a6083ab4468a1a122165ed9e2b9f2937e60b3bf202"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1130/agentshield_0.2.1130_linux_arm64.tar.gz"
      sha256 "bd61d58834935cf91998465bec388be3569713bf7542dcc356642a0ca8b9d565"
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

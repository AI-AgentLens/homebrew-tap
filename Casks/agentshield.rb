cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1668"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1668/agentshield_0.2.1668_darwin_amd64.tar.gz"
      sha256 "ab16f5f4d69a5773129d766dc84fc0ed08815298d6e83db90326ca304b305dae"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1668/agentshield_0.2.1668_darwin_arm64.tar.gz"
      sha256 "1a5404278d13bbc32f2f84193275257c55347203e71cee9c29d0c8afa21983a1"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1668/agentshield_0.2.1668_linux_amd64.tar.gz"
      sha256 "a55cca5c36e23e27ac79bace5eb2820808404958a4f8e636a5ea1818041bba1d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1668/agentshield_0.2.1668_linux_arm64.tar.gz"
      sha256 "3e48eed164d99a45e5f5e6f53adc5f0c27ab0ff9ee2ead26cb7849fdbe8811e1"
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

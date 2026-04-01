cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.276"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.276/agentshield_0.2.276_darwin_amd64.tar.gz"
      sha256 "0d5def548d3ed3a1e5112a5ed09e3ebeb1ea6192a9c99fb10e90a3665ac606d0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.276/agentshield_0.2.276_darwin_arm64.tar.gz"
      sha256 "17cf44c7e0479d1a0fedc85fde1311b550864036e3c50d040be675820e683b18"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.276/agentshield_0.2.276_linux_amd64.tar.gz"
      sha256 "b198cc7e7e0c2babf97e7c827b11921f1ef1a85ca8bb09df1cc2715130b45929"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.276/agentshield_0.2.276_linux_arm64.tar.gz"
      sha256 "1c0674507855f8bfeb829b5a700eb4f0914b6c2e7be936a9cf8fd76d3a54872c"
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

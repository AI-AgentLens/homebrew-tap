cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1647"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1647/agentshield_0.2.1647_darwin_amd64.tar.gz"
      sha256 "440b66efb5dc43f4c12781258aeb868dcc182d1d2258c379e7eb6304dcbcd165"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1647/agentshield_0.2.1647_darwin_arm64.tar.gz"
      sha256 "46e6c98fa894189367eb54a0822de583bb77e845603879ddb5450f4ffb81e967"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1647/agentshield_0.2.1647_linux_amd64.tar.gz"
      sha256 "a350cd05c4dc8eed393ed3fc0d990232cb6ce168624bf4413ab21f204da3eab1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1647/agentshield_0.2.1647_linux_arm64.tar.gz"
      sha256 "9b8c10a34879355f986e14c130a31ee7f0a55af089c601f237657105aaa3384c"
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

cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1799"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1799/agentshield_0.2.1799_darwin_amd64.tar.gz"
      sha256 "ecccafb0215d1ab20605d5057295fdc1d0c9d277edb5212d23cfde9032119eeb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1799/agentshield_0.2.1799_darwin_arm64.tar.gz"
      sha256 "80455d66607617aa1d4e99e0ad17e69b8c358fa699ff282a44dea0908ef042c1"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1799/agentshield_0.2.1799_linux_amd64.tar.gz"
      sha256 "96fbc3dcdb31472680e336fa9a81c28c35d1987a0d6bac49c91947e47a6ebf14"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1799/agentshield_0.2.1799_linux_arm64.tar.gz"
      sha256 "15e6034041e893f29eb6039833170a5ee1551bf1a2abf9d69606681aa61940bc"
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

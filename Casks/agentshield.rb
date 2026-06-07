cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1233"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1233/agentshield_0.2.1233_darwin_amd64.tar.gz"
      sha256 "26f158991c48b0b0999ac2915eedbbb7653148288a6b321dd22ddfccbaf044e9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1233/agentshield_0.2.1233_darwin_arm64.tar.gz"
      sha256 "61cc736f7080fe644ec0dee58449e38ac800a5d06a72f44b689f7480654f01d6"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1233/agentshield_0.2.1233_linux_amd64.tar.gz"
      sha256 "5187c024c3cecd6f6d2d415012568a1a997759de4deec40be2c61c6500736719"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1233/agentshield_0.2.1233_linux_arm64.tar.gz"
      sha256 "53a5beaa1302e41ff973ae68dded273bf52eb14326c9abc5032617b823c7a0ef"
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

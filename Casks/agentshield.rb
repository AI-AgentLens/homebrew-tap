cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.939"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.939/agentshield_0.2.939_darwin_amd64.tar.gz"
      sha256 "f7db0358c69ce1afa4f9869eb7e29643a1b46b4285da53a08b9df3fb3e62c995"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.939/agentshield_0.2.939_darwin_arm64.tar.gz"
      sha256 "2d6d6322cba11b974e68828256b5748047f238aed48e2de6d2095dc7c7731a22"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.939/agentshield_0.2.939_linux_amd64.tar.gz"
      sha256 "aad08ed15c5795acc3292392bf7063133de5413161ecc20cfc37d5d26432318f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.939/agentshield_0.2.939_linux_arm64.tar.gz"
      sha256 "b901609001dfbe4f3ff7f14a59e5e3d49f92c8df4188bc3fab6b858cb58488c8"
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

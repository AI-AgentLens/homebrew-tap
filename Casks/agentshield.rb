cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.212"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.212/agentshield_0.2.212_darwin_amd64.tar.gz"
      sha256 "800bc977315eed8135e6d4e1cf45829948050b756e22b8b8ae41002bb26f632e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.212/agentshield_0.2.212_darwin_arm64.tar.gz"
      sha256 "b6973517a8f0268d1d82e5136738aa5b475cd4c483cdbdc69dbc63e916506290"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.212/agentshield_0.2.212_linux_amd64.tar.gz"
      sha256 "784ba6b92cafc63b6849bb8c836f365c107bab2f105b670ff3bde351adb04b57"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.212/agentshield_0.2.212_linux_arm64.tar.gz"
      sha256 "2b95954216b39ad5fcef5b825bdc21ca50dcb921f923e012c05cbfa72e2d54e1"
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

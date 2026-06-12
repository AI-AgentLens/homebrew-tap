cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1294"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1294/agentshield_0.2.1294_darwin_amd64.tar.gz"
      sha256 "03d8ef51e09a38bff294691e6c214b131e22cc4ec51899d377196846303311b3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1294/agentshield_0.2.1294_darwin_arm64.tar.gz"
      sha256 "4c62a99db5a30a9d773dcbd39b5f7e1fb41a1622c24782f24465848e779c916e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1294/agentshield_0.2.1294_linux_amd64.tar.gz"
      sha256 "99242b677a3eb330ed0e042f3b948f12a006b1960ffd42bd042410727c90ee39"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1294/agentshield_0.2.1294_linux_arm64.tar.gz"
      sha256 "553818c4ac91f02712b3eca95d2b974778e2dd43efc85e9f3d9a674efbf322d0"
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

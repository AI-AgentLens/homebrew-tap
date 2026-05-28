cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1128"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1128/agentshield_0.2.1128_darwin_amd64.tar.gz"
      sha256 "5414d9bc5acdba74d3cb8a18f562b6f074d25d0be3a48ae80e2439ce130eb002"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1128/agentshield_0.2.1128_darwin_arm64.tar.gz"
      sha256 "96cc3f280fb64d7c0522e0660593d080763321256418daf3fbecc6b2b4715858"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1128/agentshield_0.2.1128_linux_amd64.tar.gz"
      sha256 "8e7c3b50e7f3158dc86354cdff60c5e7583ee29f262f9bf9948761711c921c29"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1128/agentshield_0.2.1128_linux_arm64.tar.gz"
      sha256 "32fdc2fb3a723a7fa97658c358a45c20281c5e20541e9638cc110054e0999a83"
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

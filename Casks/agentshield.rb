cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.520"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.520/agentshield_0.2.520_darwin_amd64.tar.gz"
      sha256 "be5b1613c487d2cf6c97db4c6c24b65bd368450d64533c11c9f8e28da431cf9c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.520/agentshield_0.2.520_darwin_arm64.tar.gz"
      sha256 "9d1e6b1e7754c88df5a936ccb4b8e722aca7b32344794bcf89e48b1c296edd16"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.520/agentshield_0.2.520_linux_amd64.tar.gz"
      sha256 "a0c90d3234512a9246d679e2f1c1b98df644f3e3d7555cb8e1c64308f7b91579"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.520/agentshield_0.2.520_linux_arm64.tar.gz"
      sha256 "f5eb2481ea50e8c4740fb945da00ca1ceb27085a23ed05e951fd16581c79847f"
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

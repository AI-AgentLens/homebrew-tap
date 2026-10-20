cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2483"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2483/agentshield_0.2.2483_darwin_amd64.tar.gz"
      sha256 "192eac877b22da036ad09100550b7559420c21023ae21cfea61df2195fed264d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2483/agentshield_0.2.2483_darwin_arm64.tar.gz"
      sha256 "2663b25b2b35818356bc0102f0ea4ffa6e1b972a47292639b3f3a91c8257abe6"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2483/agentshield_0.2.2483_linux_amd64.tar.gz"
      sha256 "844e5ef3541abc391101e8e589b044132ff76632302d992697c26211ca7d7d98"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2483/agentshield_0.2.2483_linux_arm64.tar.gz"
      sha256 "a673e74efd7868b57904de7227171f8d592194902d232db801075729a833e6a3"
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

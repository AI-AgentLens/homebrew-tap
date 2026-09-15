cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2150"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2150/agentshield_0.2.2150_darwin_amd64.tar.gz"
      sha256 "9741a0f87d89cb782a1ca03f3111e5e1f5797db07f9696f29b9a9c1d8aabf9ea"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2150/agentshield_0.2.2150_darwin_arm64.tar.gz"
      sha256 "c6f61f15c911d5ab9ede436b4dcc3668f3fda020a96798dcb1709807f806905e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2150/agentshield_0.2.2150_linux_amd64.tar.gz"
      sha256 "2368ded603105c64d97a63a5946925fe2acc8d1cde0f5b2a4935d626163fbb00"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2150/agentshield_0.2.2150_linux_arm64.tar.gz"
      sha256 "59e5886b49f603bf9c1c5ad26785d760cbf9b726e7c9b5e117c973abfba37f2a"
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

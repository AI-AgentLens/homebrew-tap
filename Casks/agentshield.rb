cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.665"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.665/agentshield_0.2.665_darwin_amd64.tar.gz"
      sha256 "6f97de0ecb67546a7d9e50ca4ff7f8c48ab31bdbc207d5d2989865ae14a4ddc5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.665/agentshield_0.2.665_darwin_arm64.tar.gz"
      sha256 "7056c47586641c4ce02af6fb308edad97cfc58f867f5ed3cd72d7f2f5258fd77"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.665/agentshield_0.2.665_linux_amd64.tar.gz"
      sha256 "9ff12434df2e0351fc0d0c39c0d71762f83dcee07be1dfdeaf6fadd215c41dd9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.665/agentshield_0.2.665_linux_arm64.tar.gz"
      sha256 "f35aadd2f25982345e0da223919444582a1a5174c1220be6e6efdbd5550450ce"
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

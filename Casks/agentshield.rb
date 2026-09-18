cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2174"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2174/agentshield_0.2.2174_darwin_amd64.tar.gz"
      sha256 "d3433bae8345544d2a54f26b74bdc07306e5b3157adeeb16fafec52633319607"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2174/agentshield_0.2.2174_darwin_arm64.tar.gz"
      sha256 "65623b4c14a5e7319a0b31b58a97266b035c5b3dee0931f15bfd6cc1374e1166"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2174/agentshield_0.2.2174_linux_amd64.tar.gz"
      sha256 "cae722e2fb92987aae45a0fd955a05ff9b22c5fe393bcf5b341b40c66cb6f6a0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2174/agentshield_0.2.2174_linux_arm64.tar.gz"
      sha256 "d9991c1ef2deed5ff69ec22b31110faaa5818241f402bfee3aa6cd8fc8caf311"
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

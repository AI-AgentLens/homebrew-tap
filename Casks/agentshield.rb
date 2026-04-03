cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.346"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.346/agentshield_0.2.346_darwin_amd64.tar.gz"
      sha256 "f3356ad90b350716265538696fa2f4190da562e171c065b557268e0c8d081054"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.346/agentshield_0.2.346_darwin_arm64.tar.gz"
      sha256 "f1ee503865c07e4eadb276db56d95c893d098e7049d545d4cc23247fcb73aca1"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.346/agentshield_0.2.346_linux_amd64.tar.gz"
      sha256 "947961e07dff02896755236b81f40cf26a0078544b0f8de3373be099decf8660"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.346/agentshield_0.2.346_linux_arm64.tar.gz"
      sha256 "4d19e1130f15970f0a1c9f25dd937f89d3ef3cd6d8dfacc08c29a74af30dcb08"
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
